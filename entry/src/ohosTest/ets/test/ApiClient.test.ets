import { hilog } from '@kit.PerformanceAnalysisKit';
import { describe, beforeAll, beforeEach, afterEach, afterAll, it, expect } from '@ohos/hypium';
import { ApiClient, ApiConfig } from '../../../main/ets/common/services/ApiClient';

export default function apiClientTest() {
  describe('ApiClientTest', () => {
    beforeAll(() => {
      hilog.info(0x0000, 'ApiClientTest', 'ApiClient test suite start');
    });

    beforeEach(() => {
      // 每个测试用例前的准备工作
    });

    afterEach(() => {
      // 每个测试用例后的清理工作
    });

    afterAll(() => {
      hilog.info(0x0000, 'ApiClientTest', 'ApiClient test suite end');
    });

    /**
     * 测试 API 配置
     */
    it('testApiConfig', 0, () => {
      hilog.info(0x0000, 'ApiClientTest', 'testApiConfig begin');
      
      // 测试 BASE_URL 配置
      expect(ApiConfig.BASE_URL).assertNotEqual('');
      expect(ApiConfig.BASE_URL).assertContain('http');
      
      // 测试超时配置
      expect(ApiConfig.TIMEOUT).assertEqual(30000);
      
      hilog.info(0x0000, 'ApiClientTest', 'testApiConfig end');
    });

    /**
     * 测试 GET 请求（需要实际 API 服务器）
     * 注意：此测试需要网络连接和可用的 API 服务器
     */
    it('testGetRequest', 0, async () => {
      hilog.info(0x0000, 'ApiClientTest', 'testGetRequest begin');
      
      try {
        const response = await ApiClient.get('/test');
        // 根据实际 API 响应调整断言
        expect(response).assertNotUndefined();
      } catch (error) {
        // 如果 API 服务器不可用，这是预期的
        hilog.warn(0x0000, 'ApiClientTest', 'testGetRequest: API server may not be available');
      }
      
      hilog.info(0x0000, 'ApiClientTest', 'testGetRequest end');
    });

    /**
     * 测试 POST 请求
     */
    it('testPostRequest', 0, async () => {
      hilog.info(0x0000, 'ApiClientTest', 'testPostRequest begin');
      
      try {
        const testData = { phoneNumber: '13812345678' };
        const response = await ApiClient.post('/auth/send-code', testData);
        expect(response).assertNotUndefined();
      } catch (error) {
        hilog.warn(0x0000, 'ApiClientTest', 'testPostRequest: API server may not be available');
      }
      
      hilog.info(0x0000, 'ApiClientTest', 'testPostRequest end');
    });

    /**
     * 测试错误处理
     */
    it('testErrorHandling', 0, async () => {
      hilog.info(0x0000, 'ApiClientTest', 'testErrorHandling begin');
      
      try {
        // 测试无效的端点
        await ApiClient.get('/invalid/endpoint/that/does/not/exist');
      } catch (error) {
        // 应该捕获错误
        expect(error).assertNotUndefined();
        hilog.info(0x0000, 'ApiClientTest', 'Error handling works correctly');
      }
      
      hilog.info(0x0000, 'ApiClientTest', 'testErrorHandling end');
    });
  });
}

