"use strict";
Object.defineProperty(exports, "__esModule", { value: true });
exports.UpdateBabyDto = void 0;
const mapped_types_1 = require("@nestjs/mapped-types");
const create_baby_dto_1 = require("./create-baby.dto");
class UpdateBabyDto extends (0, mapped_types_1.PartialType)(create_baby_dto_1.CreateBabyDto) {
}
exports.UpdateBabyDto = UpdateBabyDto;
//# sourceMappingURL=update-baby.dto.js.map