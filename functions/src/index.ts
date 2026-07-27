/**
 * Cloud Functions — app-comores-transport.
 *
 * Deux responsabilités pour ce module (Auth & bascule de rôle) :
 *  1. `onUserWrite`   : maintient à jour la sous-collection publique
 *     `users/{userId}/publicProfile/main` à partir du document privé.
 *  2. `validerChauffeur` : seul point d'entrée autorisé pour modifier
 *     `chauffeurProfile.verificationStatus`, réservé aux administrateurs
 *     (custom claim `admin: true`). Les règles Firestore interdisent
 *     toute autre modification de ce champ côté client.
 */

import { initializeApp } from "firebase-admin/app";
import { getFirestore, FieldValue } from "firebase-admin/firestore";
import { onDocumentWritten } from "firebase-functions/v2/firestore";
import { onCall, HttpsError } from "firebase-functions/v2/https";

initializeApp();
const db = getFirestore();

const ROLE_CHAUFFEUR = "chauffeur";

const STATUTS_VALIDES = ["non_soumis", "en_attente", "verifie", "rejete"] as const;
type StatutVerification = (typeof STATUTS_VALIDES)[number];

export const onUserWrite = onDocumentWritten(
  "users/{userId}",
  async (event) => {
    const { userId } = event.params;
    const apres = event.data?.after?.data();
    const publicProfileRef = db
      .collection("users")
      .doc(userId)
      .collection("publicProfile")
      .doc("main");

    // Document supprimé, ou utilisateur qui n'est plus chauffeur : on
    // retire la fiche publique associée.
    const roles: string[] = apres?.roles ?? [];
    if (!apres || !roles.includes(ROLE_CHAUFFEUR) || !apres.chauffeurProfile) {
      await publicProfileRef.delete().catch(() => undefined);
      return;
    }

    await publicProfileRef.set({
      displayName: apres.displayName ?? "",
      ratingAverage: apres.ratingAverage ?? 0,
      ratingCount: apres.ratingCount ?? 0,
      vehicule: apres.chauffeurProfile.vehicule ?? null,
      disponible: apres.chauffeurProfile.disponible ?? false,
      misAJourLe: FieldValue.serverTimestamp(),
    });
  }
);

export const validerChauffeur = onCall(async (request) => {
  if (!request.auth) {
    throw new HttpsError("unauthenticated", "Authentification requise.");
  }
  if (request.auth.token.admin !== true) {
    throw new HttpsError(
      "permission-denied",
      "Seul un administrateur peut valider un chauffeur."
    );
  }

  const uid = request.data?.uid;
  const nouveauStatut = request.data?.nouveauStatut as StatutVerification;

  if (typeof uid !== "string" || uid.length === 0) {
    throw new HttpsError("invalid-argument", "uid manquant.");
  }
  if (!STATUTS_VALIDES.includes(nouveauStatut)) {
    throw new HttpsError(
      "invalid-argument",
      `nouveauStatut doit être l'un de : ${STATUTS_VALIDES.join(", ")}`
    );
  }

  const userRef = db.collection("users").doc(uid);
  const snapshot = await userRef.get();
  if (!snapshot.exists || !snapshot.data()?.chauffeurProfile) {
    throw new HttpsError(
      "failed-precondition",
      "Cet utilisateur n'a pas de profil chauffeur à valider."
    );
  }

  await userRef.update({
    "chauffeurProfile.verificationStatus": nouveauStatut,
  });

  return { uid, verificationStatus: nouveauStatut };
});
