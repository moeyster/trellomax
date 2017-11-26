class AwsService
  #
  # upload csv file to aws s3
  #
  def self.upload_csv_file(filename)
    s3 = Aws::S3::Resource.new(
      credentials: Aws::Credentials.new(ENV['S3_KEY'], ENV['S3_SECRET']),
      region: ENV['S3_REGION']
    )

    obj = s3.bucket(ENV['S3_BUCKET']).object(filename)
    obj.upload_file(File.open(Rails.root.join('tmp',filename)), acl:'private', content_type: 'text/csv')

    return obj
  end

  def self.get_presigned_url(key)
    s3 = Aws::S3::Resource.new(
      credentials: Aws::Credentials.new(ENV['S3_KEY'], ENV['S3_SECRET']),
      region: ENV['S3_REGION']
    )
    obj = s3.bucket(ENV['S3_BUCKET']).object(key)
    url = obj.presigned_url(:get, expires_in: 2.hours.to_i).to_s
    return url
  end
end
