import { readFile } from 'node:fs/promises';
import { after, before, beforeEach, test } from 'node:test';
import { initializeTestEnvironment, assertFails, assertSucceeds } from '@firebase/rules-unit-testing';
import { doc, getDoc, setDoc, updateDoc, deleteDoc } from 'firebase/firestore';

let environment;
before(async () => {
  const rules = await readFile(process.env.FIRESTORE_RULES_FILE ?? '../firestore.rules', 'utf8');
  environment = await initializeTestEnvironment({ projectId: 'demo-semana16', firestore: { rules } });
});
beforeEach(async () => environment.clearFirestore());
after(async () => environment?.cleanup());

test('cada usuario puede crear, leer, actualizar y eliminar sus tareas', async () => {
  const db = environment.authenticatedContext('usuario-a').firestore();
  const ref = doc(db, 'users/usuario-a/tasks/tarea-1');
  await assertSucceeds(setDoc(ref, { title: 'Comprar café' }));
  await assertSucceeds(getDoc(ref));
  await assertSucceeds(updateDoc(ref, { title: 'Comprar té' }));
  await assertSucceeds(deleteDoc(ref));
});
test('otro usuario no puede leer, modificar ni eliminar tareas ajenas', async () => {
  await environment.withSecurityRulesDisabled(async context => setDoc(doc(context.firestore(), 'users/usuario-a/tasks/tarea-1'), { title: 'Privado' }));
  const db = environment.authenticatedContext('usuario-b').firestore();
  const ref = doc(db, 'users/usuario-a/tasks/tarea-1');
  await assertFails(getDoc(ref));
  await assertFails(setDoc(ref, { title: 'Intrusión' }));
  await assertFails(updateDoc(ref, { title: 'Intrusión' }));
  await assertFails(deleteDoc(ref));
});
test('una persona sin sesión no accede a tareas ni a tokens', async () => {
  const db = environment.unauthenticatedContext().firestore();
  await assertFails(getDoc(doc(db, 'users/usuario-a/tasks/tarea-1')));
  await assertFails(setDoc(doc(db, 'users/usuario-a'), { fcmToken: 'token-prueba' }));
});
test('el token del usuario solo es accesible para su propietario', async () => {
  const owner = environment.authenticatedContext('usuario-a').firestore();
  const other = environment.authenticatedContext('usuario-b').firestore();
  await assertSucceeds(setDoc(doc(owner, 'users/usuario-a'), { fcmToken: 'token-prueba' }));
  await assertFails(getDoc(doc(other, 'users/usuario-a')));
  await assertFails(updateDoc(doc(other, 'users/usuario-a'), { fcmToken: 'otro-token' }));
});
