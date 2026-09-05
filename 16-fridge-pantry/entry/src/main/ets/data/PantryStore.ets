import { preferences } from '@kit.ArkData';

export interface PantryItem {
  id: number;
  name: string;
  notedDate: string;
  place: string;
}

export class PantryStore {
  async load(context: Context): Promise<PantryItem[]> {
    const store = await preferences.getPreferences(context, 'fridge-pantry-items');
    const value = await store.get('items', '') as string;
    try {
      const items = value.length > 0 ? JSON.parse(value) as PantryItem[] : [];
      return items.map((item: PantryItem) => {
        return {
          id: item.id,
          name: item.name,
          notedDate: item.notedDate,
          place: item.place ?? ''
        } as PantryItem;
      });
    } catch {
      return [];
    }
  }

  async save(context: Context, items: PantryItem[]): Promise<void> {
    const store = await preferences.getPreferences(context, 'fridge-pantry-items');
    await store.put('items', JSON.stringify(items));
    await store.flush();
  }
}
