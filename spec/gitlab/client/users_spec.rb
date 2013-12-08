require 'spec_helper'

describe Gitlab::Client do
  describe ".users" do
    before do
      stub_get("/users", "users")
      @users = Gitlab.users
    end

    it "should get the correct resource" do
      a_get("/users").should have_been_made
    end

    it "should return an array of users" do
      @users.should be_an Array
      @users.first.email.should == "john@example.com"
    end
  end

  describe ".user" do
    context "with user ID passed" do
      before do
        stub_get("/users/1", "user")
        @user = Gitlab.user(1)
      end

      it "should get the correct resource" do
        a_get("/users/1").should have_been_made
      end

      it "should return information about a user" do
        @user.email.should == "john@example.com"
      end
    end

    context "without user ID passed" do
      before do
        stub_get("/user", "user")
        @user = Gitlab.user
      end

      it "should get the correct resource" do
        a_get("/user").should have_been_made
      end

      it "should return information about an authorized user" do
        @user.email.should == "john@example.com"
      end
    end
  end

  describe ".create_user" do
    context "when successful request" do
      before do
        stub_post("/users", "user")
        @user = Gitlab.create_user("email", "pass")
      end

      it "should get the correct resource" do
        body = {:email => "email", :password => "pass", :name => "email"}
        a_post("/users").with(:body => body).should have_been_made
      end

      it "should return information about a created user" do
        @user.email.should == "john@example.com"
      end
    end

    context "when bad request" do
      it "should throw an exception" do
        stub_post("/users", "error_already_exists", 409)
        expect {
          Gitlab.create_user("email", "pass")
        }.to raise_error(Gitlab::Error::Conflict, "Server responded with code 409, message: 409 Already exists. Request URI: #{Gitlab.endpoint}/users")
      end
    end
  end

  describe ".edit_user" do
    before do
      @options = { :name => "Roberto" }
      stub_put("/users/1", "user").with(:body => @options)
      @user = Gitlab.edit_user(1, @options)
    end

    it "should get the correct resource" do
      a_put("/users/1").with(:body => @options).should have_been_made
    end
  end

  describe ".session" do
    before do
      stub_post("/session", "session")
      @session = Gitlab.session("email", "pass")
    end

    it "should get the correct resource" do
      a_post("/session").should have_been_made
    end

    it "should return information about a created session" do
      @session.email.should == "john@example.com"
      @session.private_token.should == "qEsq1pt6HJPaNciie3MG"
    end
  end

  describe ".ssh_keys" do
    before do
      stub_get("/user/keys", "keys")
      @keys = Gitlab.ssh_keys
    end

    it "should get the correct resource" do
      a_get("/user/keys").should have_been_made
    end

    it "should return an array of SSH keys" do
      @keys.should be_an Array
      @keys.first.title.should == "narkoz@helium"
    end
  end

  describe ".ssh_key" do
    before do
      stub_get("/user/keys/1", "key")
      @key = Gitlab.ssh_key(1)
    end

    it "should get the correct resource" do
      a_get("/user/keys/1").should have_been_made
    end

    it "should return information about an SSH key" do
      @key.title.should == "narkoz@helium"
    end
  end

  describe ".create_ssh_key" do
    before do
      stub_post("/user/keys", "key")
      @key = Gitlab.create_ssh_key("title", "body")
    end

    it "should get the correct resource" do
      body = {:title => "title", :key => "body"}
      a_post("/user/keys").with(:body => body).should have_been_made
    end

    it "should return information about a created SSH key" do
      @key.title.should == "narkoz@helium"
    end
  end

  describe ".delete_ssh_key" do
    before do
      stub_delete("/user/keys/1", "key")
      @key = Gitlab.delete_ssh_key(1)
    end

    it "should get the correct resource" do
      a_delete("/user/keys/1").should have_been_made
    end

    it "should return information about a deleted SSH key" do
      @key.title.should == "narkoz@helium"
    end
  end
end
