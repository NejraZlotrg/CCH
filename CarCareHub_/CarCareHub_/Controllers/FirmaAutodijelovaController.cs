using Microsoft.AspNetCore.Mvc;
using CarCareHub.Services;
using CarCareHub.Services.Database;

namespace CarCareHub_.Controllers
{
    [ApiController]
    [Route("controllerFM")]
    public class FirmaAutodijelovaController : ControllerBase
    {
      
        private readonly IFirmaAutodijelovaService _service;
        private readonly ILogger< WeatherForecastController> _logger ;

        public FirmaAutodijelovaController (ILogger<WeatherForecastController> logger, IFirmaAutodijelovaService service)
        {
            _logger = logger;   
            _service = service;
        }
       
        [HttpGet]
        [Route("/FirmaAutodijelova/get")]
        public IEnumerable<CarCareHub.Model.FirmaAutodijelova> Get()
        {
            return _service.Get();
        }
        [HttpPost]
      public  CarCareHub.Model.FirmaAutodijelova Add(CarCareHub.Model.FirmaAutodijelovaInsert insert)
        {
            return _service.Add(insert);
        }
        [HttpPut]
        public CarCareHub.Model.FirmaAutodijelova Update(int id, CarCareHub.Model.FirmaAutodijelovaUpdate update)
        {
            return _service.Update(id, update);
        }
    }
}
