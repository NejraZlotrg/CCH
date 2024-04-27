using CarCareHub.Model;
using CarCareHub.Model.SearchObjects;
using CarCareHub.Services;
using Microsoft.AspNetCore.Mvc;

namespace CarCareHub_.Controllers
{
    [ApiController]
    [Route("api/chatKlijentZaposlenik")]
    public class ChatKlijentZapolenikController : BaseCRUDController<ChatKlijentZaposlenik, ChatKlijentZaposlenikSearchObject, ChatKlijentZaposlenikInsert, ChatKlijentZaposlenikUpdate>
    {
        public ChatKlijentZapolenikController(ILogger<BaseController<ChatKlijentZaposlenik, ChatKlijentZaposlenikSearchObject>> logger,
             IChatKlijentZaposlenikService Service) : base(logger, Service)
        {
        }

    }
}
