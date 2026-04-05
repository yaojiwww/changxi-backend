import { NestFactory } from '@nestjs/core';
import { AppModule } from './app.module';

async function bootstrap() {
  const app = await NestFactory.create(AppModule);
  // 监听所有网络接口，这样真机可以访问
  await app.listen(3000, '0.0.0.0');
}
bootstrap();
