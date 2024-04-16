using CarCareHub.Model;
using CarCareHub.Model.SearchObjects;
using CarCareHub.Services;
using Microsoft.AspNetCore.Mvc;

namespace CarCareHub_.Controllers
{
    [ApiController]
    [Route("api/chatKlijentAutoservis")]
    public class ChatKlijentServisController : BaseCRUDController<ChatKlijentServis, ChatKlijentServisSearchObject, ChatKlijentServisInsert, ChatKlijentServisUpdate>
    {
        public ChatKlijentServisController(ILogger<BaseController<ChatKlijentServis, ChatKlijentServisSearchObject>> logger,
             IChatKlijentServisService Service) : base(logger, Service)
        {
        }

    }
}
