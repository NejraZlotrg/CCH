using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace CarCareHub.Services
{
    public interface IFirmaAutodijelovaService
    {
        List<Model.FirmaAutodijelova> Get();
        Model.FirmaAutodijelova Add(Model.FirmaAutodijelovaInsert insert);
        Model.FirmaAutodijelova Update(int id, Model.FirmaAutodijelovaUpdate update);
    }
}
