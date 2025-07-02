import { ResponseMessage } from '../common/decorator/response.decorator';
import { Controller, Post, Body, Get } from '@nestjs/common';
import { RestaurantsService } from './restaurants.service';
import { CreateRestaurantDto } from './dto/create-restaurant.dto';
import { Restaurant } from 'generated/prisma';

@Controller('restaurants')
export class RestaurantsController {
  constructor(private readonly restaurantService: RestaurantsService) {}

  @ResponseMessage('Restaurant created successfully')
  @Post()
  async create(@Body() dto: CreateRestaurantDto): Promise<Restaurant> {
    return await this.restaurantService.create(dto);
  }

  @ResponseMessage('Restaurant fetched successfully')
  @Get()
  async findAll() {
    return await this.restaurantService.findAll();
  }
}
