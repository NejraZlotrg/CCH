using CarCareHub.Model;
using Microsoft.AspNetCore.Mvc;
using Microsoft.AspNetCore.Mvc.Filters;
using System.Net;

namespace CarCareHub_.Errors
{
    public class ErrorFilter: ExceptionFilterAttribute
    {
        public override void OnException(ExceptionContext context)
        {
            if ( context.Exception is UserException)
            {
                context.ModelState.AddModelError("user error", context.Exception.Message);
                context.HttpContext.Response.StatusCode = (int)HttpStatusCode.BadRequest;
            }
            else
            {
            context.ModelState.AddModelError("ERROR", "Server Side Error");
                context.HttpContext.Response.StatusCode = (int)HttpStatusCode.InternalServerError;
            }
            var list = context.ModelState.Where(x => x.Value.Errors.Count()>0).ToDictionary(x => x.Key, y => y.Value.Errors.Select(z=>z.ErrorMessage));
            context.Result = new JsonResult(new { errors = list });
        }
    }
}
