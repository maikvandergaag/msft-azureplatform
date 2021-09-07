using demo.core;
using demo.core.Interfaces;
using Microsoft.AspNetCore.Mvc.RazorPages;
using Microsoft.Extensions.Logging;
using Newtonsoft.Json;
using System.Collections.Generic;

namespace demo.webapp.Pages
{
    public class IndexModel : PageModel
    {
        private readonly ILogger<IndexModel> _logger;

        private IAPIRepository repository;

        public IList<WeatherForecast> Forecasts { get; set; }

        public IndexModel(ILogger<IndexModel> logger, IAPIRepository repo)
        {
            _logger = logger;
            repository = repo;
        }

        public void OnGet()
        {
            string result = repository.Get("WeatherForecast");
            Forecasts =  JsonConvert.DeserializeObject<List<WeatherForecast>>(result);
        }
    }
}
