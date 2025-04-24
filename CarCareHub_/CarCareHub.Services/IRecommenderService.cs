using CarCareHub.Model.SearchObjects;
using CarCareHub.Services.Database;

namespace CarCareHub.Services
{
    public interface IRecommenderService
    {
        Task<List<Proizvod>> GetRecommendationsByProizvodId(long proizvod, CancellationToken cancellationToken);
        Task<PagedResult<Recommender>> TrainModelAsync(CancellationToken cancellationToken = default);
    }
}
