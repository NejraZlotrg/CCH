using CarCareHub.Model;
using CarCareHub.Model.SearchObjects;
using CarCareHub.Services;
using Microsoft.AspNetCore.Mvc;

namespace CarCareHub_.Controllers
{
    [ApiController]
    [Route("api/chatKlijentAutoservis")]
    public class ChatKlijentAutoservisController : BaseCRUDController<ChatKlijentAutoservis, ChatKlijentAutoservisSearchObject, ChatKlijentAutoservisInsert,
        ChatKlijentAutoservisUpdate>
    {
        public ChatKlijentAutoservisController(ILogger<BaseController<ChatKlijentAutoservis, ChatKlijentAutoservisSearchObject>> logger,
             IChatKlijentAutoservisService Service) : base(logger, Service)
        {
        }

    }
}
