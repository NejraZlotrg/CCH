using CarCareHub.Services.Database;

namespace CarCareHub.Services
{
    public interface IRecommenderService
    {
        Task<List<Proizvod>> GetRecommendationsByArticleId(long articleId, CancellationToken cancellationToken);
        Task<List<Recommender>> TrainModelAsync(CancellationToken cancellationToken = default);

    }
}
