import { IsString, IsNumber, IsOptional, Min, Max } from 'class-validator';

export class CreateRestaurantDto {
  @IsString()
  name: string;

  @IsNumber()
  latitude: number;

  @IsNumber()
  longitude: number;

  @IsString()
  category: string;

  @IsOptional()
  @IsString()
  description?: string;

  @IsNumber()
  @Min(1)
  @Max(5)
  rating: number;
}
