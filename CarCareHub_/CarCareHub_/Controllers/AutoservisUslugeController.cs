using CarCareHub.Model;
using CarCareHub.Model.SearchObjects;
using CarCareHub.Services;
using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;

namespace CarCareHub_.Controllers
{
    [ApiController]
    [AllowAnonymous]
    [Route("api/AutoservisUsluge")]
    public class AutoservisUslugeController : BaseCRUDController<AutoservisUsluge, AutoservisUslugeSearchObject, AutoservisUslugeInsert, AutoservisUslugeUpdate>
    {
        public AutoservisUslugeController(ILogger<BaseController<AutoservisUsluge, AutoservisUslugeSearchObject>> logger,
             IAutoservisUslugeServices Service) : base(logger, Service)
        {
        }



    }
}