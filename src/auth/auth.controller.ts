import { Controller, Post, Body } from '@nestjs/common';
import { AuthService } from './auth.service';
import { GetCodeDto } from './dto/get-code.dto';
import { RegisterDto } from './dto/register.dto';
import { LoginDto } from './dto/login.dto';

@Controller('auth')
export class AuthController {
  constructor(private readonly authService: AuthService) {}

  // 获取验证码
  @Post('get-code')
  getCode(@Body() getCodeDto: GetCodeDto) {
    return this.authService.sendCode(getCodeDto.phoneNumber);
  }

  // 注册
  @Post('register')
  register(@Body() registerDto: RegisterDto) {
    return this.authService.register(registerDto.phoneNumber, registerDto.code);
  }

  // 登录
  @Post('login')
  login(@Body() loginDto: LoginDto) {
    return this.authService.login(loginDto.phoneNumber, loginDto.code);
  }
}
