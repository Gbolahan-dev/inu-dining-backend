import { NestFactory, Reflector } from '@nestjs/core';
import { AppModule } from './app.module';
import { MyLoggerService } from './my-logger/my-logger.service';
import { ValidationPipe } from '@nestjs/common';
import * as express from 'express';
import helmet from 'helmet';
import * as hpp from 'hpp';
import { ResponseTransformerInterceptor } from './common/interceptors/response.interceptor';
import { HttpExceptionFilter } from './common/filter/filter';

async function bootstrap() {
  const app = await NestFactory.create(AppModule, {
    cors: {
      origin: '*',
      methods: '*',
    },
    bufferLogs: true,
  });

  app.use(helmet());
  app.use(hpp({}));

  app.use(express.json({ limit: '50mb' }));
  app.use(express.urlencoded({ limit: '50mb', extended: true }));

  app.useGlobalPipes(
    new ValidationPipe({
      whitelist: true, // strips unknown properties
      forbidNonWhitelisted: true, // throws error on unknown props
      transform: true,
      forbidUnknownValues: true,
    }),
  );

  //  interceptors
  app.useGlobalInterceptors(
    new ResponseTransformerInterceptor(app.get(Reflector)),
  );

  // Set global exception filter
  app.useGlobalFilters(new HttpExceptionFilter());

  app.useLogger(app.get(MyLoggerService));

  await app.listen(process.env.PORT ?? 4000);
}
bootstrap();
