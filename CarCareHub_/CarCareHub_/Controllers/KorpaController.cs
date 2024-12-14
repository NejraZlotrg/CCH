using CarCareHub.Model;
using CarCareHub.Model.SearchObjects;
using CarCareHub.Services;
using CarCareHub_.Controllers;
using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;

namespace CarCareHub_
{


    [ApiController]
    [AllowAnonymous]
    [Route("api/korpa")]
    public class KorpaController : BaseCRUDController<Korpa, KorpaSearchObject, KorpaInsert, KorpaUpdate>
    {
        public KorpaController(ILogger<BaseController<Korpa, KorpaSearchObject>> logger,
             IKorpaService korpaService) : base(logger, korpaService)
        {
        }





    }
}
