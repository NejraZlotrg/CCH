using Microsoft.AspNetCore.Mvc;
using Microsoft.AspNetCore.Mvc.Filters;

namespace CarCareHub_.Errors
{
    public class ErrorFilter: ExceptionFilterAttribute
    {
        public override void OnException(ExceptionContext context)
        {
            context.ModelState.AddModelError("ERROR", "Server Side Error");
            var list = context.ModelState.Where(x => x.Value.Errors.Count()>0).ToDictionary(x => x.Key, y => y.Value.Errors.Select(z=>z.ErrorMessage));
            context.Result = new JsonResult(new { errors = list });

           // base.OnException(context);
        }
    }
}
