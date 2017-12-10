
import XCTest
import RxSwift
import RxTest
import RxBlocking
@testable import GitHubUsers

class GitHubUsersTests: XCTestCase {
    
    var scheduler: SchedulerType?
    var apiClient: MOCKAPIClientService?
    var usersViewModelService: MockUsersViewModelService?
    var viewModel: MockUsersViewModel?
    
    override func setUp() {
        super.setUp()
        scheduler = ConcurrentDispatchQueueScheduler.init(qos: .default)
        apiClient = MOCKAPIClientService.shared
        usersViewModelService = MockUsersViewModelService()
        viewModel = MockUsersViewModel(service: usersViewModelService!)
    }
    
    override func tearDown() {
        scheduler = nil
        usersViewModelService = nil
        apiClient = nil
        viewModel = nil
        super.tearDown()
        
    }
    
    func testExample() {
        // This is an example of a functional test case.
        // Use XCTAssert and related functions to verify your tests produce the correct results.
    }
    
    func testPerformanceExample() {
        // This is an example of a performance test case.
        self.measure {
            // Put the code you want to measure the time of here.
        }
    }
    
    func test_fetchUsers() {
        guard let apiClient = apiClient, let scheduler = scheduler else {
            XCTFail()
            return
        }
        let usersObservable = apiClient.fetchUsers().subscribeOn(scheduler)
        guard let result = try? usersObservable.toBlocking().first() else {
            XCTFail()
            return
        }
        XCTAssertTrue(apiClient.fetchUsersCalled)
        XCTAssertEqual(result?.count, 30)
        XCTAssertEqual(result?.first?.login, "mojombo")
        
    }
    
    func test_fetchRepos() {
        guard let apiClient = apiClient, let scheduler = scheduler else {
            XCTFail()
            return
        }
        let reposObservable = apiClient.fetchRepos(for: nil).subscribeOn(scheduler)
        guard let result = try? reposObservable.toBlocking().first() else {
            XCTFail()
            return
        }
        XCTAssertTrue(apiClient.fetchReposCalled)
        XCTAssertEqual(result?.count, 30)
        XCTAssertEqual(result?.first?.fullName, "mojombo/30daysoflaptops.github.io")
        
    }
    
    func test_fetchAvatars() {
        guard let apiClient = apiClient, let scheduler = scheduler else {
            XCTFail()
            return
        }
        let avatarsObservable = apiClient.fetchAvatar(for: nil).subscribeOn(scheduler)
        guard let result = try? avatarsObservable.toBlocking().first() else {
            XCTFail()
            return
        }
        XCTAssertTrue(result is UIImage?)
        XCTAssertTrue(apiClient.fetchAvatarCalled)
    }
    
    func test_UsersViewModel() {
        guard let viewModel = viewModel, let scheduler = scheduler else {
            XCTFail()
            return
        }
        let fetchedUsers = viewModel.outputs.usersVariable.asObservable().subscribeOn(scheduler)
        guard let result = try? fetchedUsers.toBlocking().first() else {
            XCTFail()
            return
        }
        guard let firstUser = result?.first else {
            XCTFail()
            return
        }
        let mockAPIClient = MOCKAPIClientService.shared
        
        XCTAssertTrue(mockAPIClient.mockRequestCalled)
        XCTAssertTrue(mockAPIClient.fetchUsersCalled)
        XCTAssertTrue(mockAPIClient.fetchReposCalled)
        XCTAssertTrue(mockAPIClient.fetchAvatarCalled)
        
        
        XCTAssertEqual(result?.count, 30)
        
        XCTAssertEqual(firstUser.login, "mojombo")
        XCTAssertEqual(firstUser.repos.count, 30)
        XCTAssertEqual(firstUser.repos.first?.fullName, "mojombo/30daysoflaptops.github.io")
    }
    
    
    
}
