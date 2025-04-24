using CarCareHub.Model;
using CarCareHub.Model.SearchObjects;
using CarCareHub.Services;
using Microsoft.AspNetCore.Mvc;

namespace CarCareHub_.Controllers
{
    [ApiController]
    [Route("api/godiste")]
    public class GodisteController : BaseCRUDController<Godiste, GodisteSearchObject, GodisteInsert, GodisteUpdate>
    {
        public GodisteController(ILogger<BaseController<Godiste, GodisteSearchObject>> logger,
             IGodisteService Service) : base(logger, Service)
        {
        }
    }
}
