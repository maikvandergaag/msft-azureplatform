using demo.core.Helpers;
using demo.core.Interfaces;
using System;
using System.Net.Http;

namespace demo.core.Repositories
{
    public class APIRepository : IAPIRepository
    {
        public string BaseUrl { get; set; }

        public APIRepository(string baseUrl)
        {
            BaseUrl = baseUrl;
        }

        public string Get(string url)
        {
            string completeUrl = $"{BaseUrl}/{url}";
            bool success = false;
            string retVal = HttpHelper.PerformHttpCall(HttpMethod.Get, null, new Uri(completeUrl), null, out success);
            return retVal;  
        }

    }
}
