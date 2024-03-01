# app/workers/destroy_old_friendships_worker.rb
module MyModule
class DestroyOldFriendshipsWorker
    include ::Sidekiq::Worker
    queue_as :default
    
    def perform 
      friendships_to_delete = Friendship.where('created_at <= ? AND status = ?', 5.minutes.ago, 'declined')
      friendships_to_delete.each do |friendship|
        puts "Friendship deleted: #{friendship.inspect}"
        friendship.destroy
      end
    end
  end
end
  