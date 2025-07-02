import { Injectable } from '@nestjs/common';
import { DatabaseService } from '../database/database.service';
import { Prisma, Restaurant } from 'generated/prisma';

@Injectable()
export class RestaurantsService {
  constructor(private readonly databaseService: DatabaseService) {}

  async create(data: Prisma.RestaurantCreateInput): Promise<Restaurant> {
    return this.databaseService.restaurant.create({ data });
  }

  findAll(): Promise<Restaurant[]> {
    return this.databaseService.restaurant.findMany();
  }
}
