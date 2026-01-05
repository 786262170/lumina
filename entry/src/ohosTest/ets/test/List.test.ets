import abilityTest from './Ability.test';
import apiClientTest from './ApiClient.test';
import authServiceTest from './AuthService.test';
import imageServiceTest from './ImageService.test';
import userServiceTest from './UserService.test';
import aiServiceTest from './AIService.test';
import apiConnectionTest from './ApiConnection.test';

export default function testsuite() {
  abilityTest();
  apiClientTest();
  authServiceTest();
  imageServiceTest();
  userServiceTest();
  aiServiceTest();
  apiConnectionTest();
}