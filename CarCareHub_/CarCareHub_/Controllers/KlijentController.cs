using CarCareHub.Model.SearchObjects;
using CarCareHub.Model;
using CarCareHub.Services;
using Microsoft.AspNetCore.Mvc;

namespace CarCareHub_.Controllers
{
    [ApiController]
    [Route("api/klijent")]
    public class KlijentiController : BaseCRUDController<CarCareHub.Model.Klijent, KlijentSearchObject, KlijentInsert, KlijentUpdate>
    {
        public KlijentiController(ILogger<BaseController<CarCareHub.Model.Klijent, KlijentSearchObject>> logger,
              IKlijentService Service) : base(logger, Service)
        {
        }
    }
}