using System;
using System.Net.Http;
using System.Net.Http.Headers;
using System.Text;

namespace demo.core.Helpers
{
    public class HttpHelper
    {
        public static string PerformHttpCall(HttpMethod method, AuthenticationHeaderValue authHeader, Uri apiUri, string content, out bool success)
        {
            success = false;
            string retVal = string.Empty;

            using (HttpClient client = new HttpClient())
            {
                client.DefaultRequestHeaders.Accept.Add(new MediaTypeWithQualityHeaderValue("application/json"));
                if (authHeader != null)
                {
                    client.DefaultRequestHeaders.Authorization = authHeader;
                }

                var request = new HttpRequestMessage(method, apiUri);
                if (method == HttpMethod.Post || method == HttpMethod.Put || method == new HttpMethod("Patch"))
                {
                    request.Content = new StringContent(content, Encoding.UTF8, "application/json");
                }

                using (HttpResponseMessage response = client.SendAsync(request).Result)
                {
                    success = response.IsSuccessStatusCode;
                    retVal = response.Content.ReadAsStringAsync().Result;
                }
            }

            return retVal;
        }
    }
}
