using Microsoft.AspNetCore.Mvc;
using Microsoft.Extensions.Logging;
using CarCareHub.Model;
using CarCareHub.Model.SearchObjects;
using CarCareHub.Services;
using Microsoft.AspNetCore.Authorization;


namespace CarCareHub_.Controllers
{
    [ApiController]
    [AllowAnonymous]
    [Route("api/[controller]")]
    public class DrzavaController : BaseCRUDController<Drzava, DrzavaSearchObject, DrzavaInsert, DrzavaUpdate>
    {
        public DrzavaController(ILogger<BaseController<CarCareHub.Model.Drzava, DrzavaSearchObject>> logger,
             ICRUDService<Drzava, DrzavaSearchObject, DrzavaInsert, DrzavaUpdate> service) : base(logger, service)
        {
        }
    }
}