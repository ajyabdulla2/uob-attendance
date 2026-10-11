import { DurableObject } from 'cloudflare:workers';

/**
 * One counter for all public reads (src/public.js), in a single Durable
 * Object so every Cloudflare location shares it. It keeps only today's
 * quota day and count: a new day starts again from zero.
 */
export class PublicQuota extends DurableObject {
  async used(day) {
    return (await this.ctx.storage.get('day')) === day ? ((await this.ctx.storage.get('count')) ?? 0) : 0;
  }

  async add(day, n) {
    const count = (await this.used(day)) + n;
    await this.ctx.storage.put({ day, count });
    return count;
  }
}
