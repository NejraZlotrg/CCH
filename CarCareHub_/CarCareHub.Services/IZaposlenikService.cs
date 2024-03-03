using CarCareHub.Model;
using CarCareHub.Model.SearchObjects;
using CarCareHub.Services.Database;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace CarCareHub.Services
{
    public interface IZaposlenikService : IService<Model.Zaposlenik, ZaposlenikSearchObject>
    {
        public Model.Zaposlenik Update(int id, ZaposlenikUpdate update);
        public Model.Zaposlenik Insert(ZaposlenikInsert insert);

    }
}
