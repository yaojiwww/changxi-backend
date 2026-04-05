import { AuthService } from './auth.service';
import { GetCodeDto } from './dto/get-code.dto';
import { RegisterDto } from './dto/register.dto';
import { LoginDto } from './dto/login.dto';
export declare class AuthController {
    private readonly authService;
    constructor(authService: AuthService);
    getCode(getCodeDto: GetCodeDto): Promise<{
        code: number;
        debugCode: string;
    }>;
    register(registerDto: RegisterDto): Promise<{
        code: number;
        msg: string;
        token?: string;
        user?: import("../user/user.entity").User;
    }>;
    login(loginDto: LoginDto): Promise<{
        code: number;
        msg: string;
        token?: string;
        user?: import("../user/user.entity").User;
    }>;
}
