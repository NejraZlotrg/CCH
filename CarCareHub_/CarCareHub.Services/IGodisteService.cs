using CarCareHub.Model;
using CarCareHub.Model.SearchObjects;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace CarCareHub.Services
{
    public interface IGodisteService : ICRUDService<Godiste, GodisteSearchObject, GodisteInsert, GodisteUpdate>
    {
        public Task AddGodisteAsync();

    }
}
