import { relationalStore } from '@kit.ArkData';

export interface Observation {
  id: number;
  obstacleType: string;
  assistiveContext: string;
  passageFeeling: string;
  createdAt: string;
  visibility: string;
  reviewStatus: string;
}

export interface NewObservation {
  obstacleType: string;
  assistiveContext: string;
  passageFeeling: string;
  createdAt: string;
  visibility: string;
  reviewStatus: string;
}

const STORE_CONFIG: relationalStore.StoreConfig = {
  name: 'stepaccess-observations.db',
  securityLevel: relationalStore.SecurityLevel.S1
};
const TABLE_NAME: string = 'observations';
const CREATE_TABLE_SQL: string =
  'CREATE TABLE IF NOT EXISTS observations (' +
  'id INTEGER PRIMARY KEY AUTOINCREMENT, ' +
  'obstacle_type TEXT NOT NULL, ' +
  'assistive_context TEXT NOT NULL, ' +
  'passage_feeling TEXT NOT NULL, ' +
  'created_at TEXT NOT NULL, ' +
  'visibility TEXT NOT NULL, ' +
  'review_status TEXT NOT NULL)';

export class ObservationStore {
  private async open(context: Context): Promise<relationalStore.RdbStore> {
    const store = await relationalStore.getRdbStore(context, STORE_CONFIG);
    await store.executeSql(CREATE_TABLE_SQL);
    return store;
  }

  async load(context: Context): Promise<Observation[]> {
    const store = await this.open(context);
    const resultSet = await store.querySql(
      'SELECT id, obstacle_type, assistive_context, passage_feeling, created_at, visibility, review_status FROM observations ORDER BY id DESC'
    );
    const observations: Observation[] = [];
    try {
      while (resultSet.goToNextRow()) {
        observations.push({
          id: resultSet.getLong(0),
          obstacleType: resultSet.getString(1),
          assistiveContext: resultSet.getString(2),
          passageFeeling: resultSet.getString(3),
          createdAt: resultSet.getString(4),
          visibility: resultSet.getString(5),
          reviewStatus: resultSet.getString(6)
        });
      }
    } finally {
      resultSet.close();
    }
    return observations;
  }

  async create(context: Context, observation: NewObservation): Promise<void> {
    const store = await this.open(context);
    const values: relationalStore.ValuesBucket = {
      obstacle_type: observation.obstacleType,
      assistive_context: observation.assistiveContext,
      passage_feeling: observation.passageFeeling,
      created_at: observation.createdAt,
      visibility: observation.visibility,
      review_status: observation.reviewStatus
    };
    await store.insert(TABLE_NAME, values);
  }

  async remove(context: Context, id: number): Promise<void> {
    const store = await this.open(context);
    const predicates = new relationalStore.RdbPredicates(TABLE_NAME);
    predicates.equalTo('id', id);
    await store.delete(predicates);
  }
}
