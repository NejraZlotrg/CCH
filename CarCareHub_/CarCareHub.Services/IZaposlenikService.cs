using CarCareHub.Model.SearchObjects;
using CarCareHub.Services.Database;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace CarCareHub.Services
{
    public interface IZaposlenikService : IService<Model.Zaposlenik, GradSearchObject>
    {
    }
}
