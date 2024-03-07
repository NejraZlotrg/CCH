using CarCareHub.Services.Database;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;
using CarCareHub.Model;
using CarCareHub.Model.SearchObjects;

namespace CarCareHub.Services
{
    public interface IProizvodiService:ICRUDService<Model.Proizvod, ProizvodiSearchObject, ProizvodiInsert, ProizvodiUpdate>
    {
      
    }
}
