const test = require('node:test');
const assert = require('node:assert/strict');
const path = require('node:path');
const { DatabaseSync } = require('node:sqlite');
const sql = require(path.join(process.env.TIDEWATCH_TEST_BUILD, 'ObservationSchema.js'));
const { createObservation } = require(path.join(process.env.TIDEWATCH_TEST_BUILD, 'Observation.js'));
const item = createObservation({ title: '原始观察', place: '模拟区域', description: "中文引号 '); DROP TABLE observations; --", kind: '道路积水', risk: '未评估' }, 2, Date.parse('2026-09-22T01:00:00.000Z'), []);
function database() { const db = new DatabaseSync(':memory:'); db.exec(sql.CREATE_META); db.exec(sql.CREATE_OBSERVATIONS); return db; }
test('SQLite schema and bind order roundtrip all fields without executing text', () => {
 const db=database();
 try {
  db.prepare(sql.INSERT_RECORD).run(...sql.recordValues(item,0));
  const row=db.prepare(sql.SELECT_RECORDS).get();
  assert.equal(row.description,item.description);assert.equal(row.id,item.id);assert.equal(row.expires_at,item.expiresAt);
  assert.equal(row.source,item.source);assert.equal(row.title,item.title);assert.equal(row.kind,item.kind);assert.equal(row.updated_at,item.updatedAt);
 } finally { db.close(); }
});
test('SQLite replacement transaction rollback retains previous collection', () => {
 const db=database();
 try {
  db.prepare(sql.INSERT_RECORD).run(...sql.recordValues(item,0));
  db.exec("CREATE TRIGGER stop_insert BEFORE INSERT ON observations BEGIN SELECT RAISE(ABORT,'fault'); END");
  db.exec('BEGIN IMMEDIATE');db.exec(sql.DELETE_RECORDS);
  assert.throws(()=>db.prepare(sql.INSERT_RECORD).run(...sql.recordValues(item,0)));
  db.exec('ROLLBACK');assert.equal(db.prepare(sql.SELECT_RECORDS).all().length,1);
 } finally { db.close(); }
});
test('migration marker survives empty collection and unique IDs prevent duplicates', () => {
 const db=database();
 try {
  db.prepare(sql.INSERT_VERSION).run(sql.DATABASE_VERSION);
  db.prepare(sql.INSERT_RECORD).run(...sql.recordValues(item,0));
  assert.throws(()=>db.prepare(sql.INSERT_RECORD).run(...sql.recordValues(item,1)));
  db.exec(sql.DELETE_RECORDS);
  assert.equal(db.prepare(sql.SELECT_VERSION).get().value,sql.DATABASE_VERSION);
 } finally { db.close(); }
});
