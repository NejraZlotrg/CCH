using Microsoft.AspNetCore.Mvc;
using Microsoft.Extensions.Logging;
using CarCareHub.Model;
using CarCareHub.Model.SearchObjects;
using CarCareHub.Services;
using Microsoft.AspNetCore.Authorization;


namespace CarCareHub_.Controllers
{
    [ApiController]
    [Route("api/drzava")]
    public class DrzavaController : BaseCRUDController<Drzava, DrzavaSearchObject, DrzavaInsert, DrzavaUpdate>
    {
        public DrzavaController(ILogger<BaseController<CarCareHub.Model.Drzava, DrzavaSearchObject>> logger,
             IDrzavaService drzavaService) : base(logger, drzavaService)
        {
        }
    }
}