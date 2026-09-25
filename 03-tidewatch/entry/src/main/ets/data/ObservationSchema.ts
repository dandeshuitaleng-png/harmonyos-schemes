import { ObservationDraft } from './Observation';

export const DATABASE_NAME: string = 'tidewatch.db';
export const DATABASE_VERSION: string = '1';
export const CREATE_META: string = 'CREATE TABLE IF NOT EXISTS observation_meta (key TEXT PRIMARY KEY NOT NULL, value TEXT NOT NULL)';
export const CREATE_OBSERVATIONS: string = `CREATE TABLE IF NOT EXISTS observations (
  id INTEGER PRIMARY KEY NOT NULL,
  position INTEGER NOT NULL UNIQUE CHECK(position >= 0),
  source TEXT NOT NULL, collected_at TEXT NOT NULL, expires_at TEXT NOT NULL,
  status TEXT NOT NULL, title TEXT NOT NULL, place TEXT NOT NULL,
  description TEXT NOT NULL, kind TEXT NOT NULL, risk TEXT NOT NULL, updated_at TEXT NOT NULL
)`;
export const SELECT_VERSION: string = "SELECT value FROM observation_meta WHERE key = 'schema_version'";
export const INSERT_VERSION: string = "INSERT INTO observation_meta (key, value) VALUES ('schema_version', ?)";
export const SELECT_RECORDS: string = 'SELECT id, source, collected_at, expires_at, status, title, place, description, kind, risk, updated_at FROM observations ORDER BY position ASC';
export const INSERT_RECORD: string = 'INSERT INTO observations (id, position, source, collected_at, expires_at, status, title, place, description, kind, risk, updated_at) VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?)';
export const DELETE_RECORDS: string = 'DELETE FROM observations';
export type SqlValue = string | number;
export function recordValues(item: ObservationDraft, position: number): SqlValue[] {
  return [item.id, position, item.source, item.collectedAt, item.expiresAt, item.status,
    item.title, item.place, item.description, item.kind, item.risk, item.updatedAt];
}
