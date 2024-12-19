using CarCareHub.Model;
using CarCareHub.Model.SearchObjects;
using CarCareHub.Services;
using Microsoft.AspNetCore.Mvc;


namespace CarCareHub_.Controllers
{
    [ApiController]
    [Route("api/[controller]")]
    public class ChatAutoservisKlijentController : BaseCRUDController<ChatAutoservisKlijent, ChatAKSearchObject, ChatAutoservisKlijentInsert, ChatAutoservisKlijentUpdate>
    {
        public ChatAutoservisKlijentController(ILogger<BaseController<CarCareHub.Model.ChatAutoservisKlijent, ChatAKSearchObject>> logger,
              IChatAutoservisKlijentService chatService) : base(logger, chatService)
        {
        }


        [HttpPost("posalji")] 
        public async Task SendMessageAsync(int klijentId, int autoservisId, string poruka, bool poslanoOdKlijenta)
        {
            await (_service as IChatAutoservisKlijentService).SendMessageAsync(klijentId, autoservisId, poruka, poslanoOdKlijenta);
            return;

        }
    }
}
