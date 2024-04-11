using Microsoft.AspNetCore.Mvc;
using CarCareHub.Services;
using CarCareHub.Services.Database;
using CarCareHub.Model.SearchObjects;
using CarCareHub.Model;

namespace CarCareHub_.Controllers
{
    [ApiController]
    [Route("api/[controller]")]
    public class PopustController : BaseCRUDController<CarCareHub.Model.Popust, PopustSearchObject, PopustInsert, PopustUpdate>
    {


        public PopustController(ILogger<BaseController<CarCareHub.Model.Popust, PopustSearchObject>> logger,
            IPopustService PopustService) : base(logger, PopustService)
        {
           
        }
     
    }
}
