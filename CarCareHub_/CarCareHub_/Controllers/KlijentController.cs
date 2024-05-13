using CarCareHub.Model.SearchObjects;
using CarCareHub.Model;
using CarCareHub.Services;
using Microsoft.AspNetCore.Mvc;
using Microsoft.AspNetCore.Authorization;

namespace CarCareHub_.Controllers
{
    [ApiController]
    [AllowAnonymous]
    [Route("api/klijent")]
    //[Authorize]
    public class KlijentiController : BaseCRUDController<CarCareHub.Model.Klijent, KlijentSearchObject, KlijentInsert, KlijentUpdate>
    {
        public KlijentiController(ILogger<BaseController<CarCareHub.Model.Klijent, KlijentSearchObject>> logger,
              IKlijentService Service) : base(logger, Service)
        {
        }
    }
}