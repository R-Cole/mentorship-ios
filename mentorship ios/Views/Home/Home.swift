//
//  Home.swift
//  Created on 05/06/20.
//  Created for AnitaB.org Mentorship-iOS
//

import SwiftUI

struct Home: View {
    var homeService: HomeService = HomeAPI()
    var profileService: ProfileService = ProfileAPI()
    @ObservedObject var homeViewModel = HomeViewModel()
    private var relationsData: UIHelper.HomeScreen.RelationsListData {
        return homeViewModel.relationsListData
    }
     
    
    func useHomeService() {
        // fetch dashboard and map to home view model
        self.homeService.fetchDashboard { home in
            home.update(viewModel: self.homeViewModel)
            self.homeViewModel.isLoading = false
        }
        
        // if first time load, load profile too and use isLoading state (used to express in UI).
        if self.homeViewModel.firstTimeLoad {
            // set isLoading to true (expressed in UI)
            self.homeViewModel.isLoading = true
            
            // fetch profile and map to home view model.
            self.profileService.getProfile { profile in
                profile.update(viewModel: self.homeViewModel)
                // set first time load to false
                self.homeViewModel.firstTimeLoad = false
            }
        }
    }
    
    func getUserFirstName(fullName: String?) -> String {
         
        //Return just the first name
        if let editFullName = fullName ?? "" {
            
            //Field validation
            //get rid of any spaces before the beginning of the name
            let trimmedFullName = editFullName.trimmingCharacters(in: .whitespaces)
            
            if let index = trimmedFullName.firstIndex(of: " ") {
                let firstName = String(trimmedFullName.prefix(upTo: index))
                return firstName
            }
        }
         
        return ""
    }
    
    var body: some View {
        NavigationView {
            List {
                //Top space
                Section {
                    EmptyView()
                }

                //Relation dashboard list
                Section {
                    ForEach(0 ..< relationsData.relationTitle.count) { index in
                        NavigationLink(destination: RelationDetailList(
                            index: index,
                            navigationTitle: self.relationsData.relationTitle[index],
                            homeViewModel: self.homeViewModel
                        )) {
                            RelationListCell(
                                systemImageName: self.relationsData.relationImageName[index],
                                imageColor: self.relationsData.relationImageColor[index],
                                title: self.relationsData.relationTitle[index],
                                count: self.relationsData.relationCount[index]
                            )
                        }
                        .disabled(self.homeViewModel.isLoading)
                    }
                }

                //Tasks to do list section
                TasksSection(tasks: homeViewModel.homeResponseData.tasksToDo, isToDoSection: true)

                //Tasks done list section
                TasksSection(tasks: homeViewModel.homeResponseData.tasksDone)

            }
            .listStyle(GroupedListStyle())
            .environment(\.horizontalSizeClass, .regular)
            .navigationBarTitle("Welcome \(getUserFirstName(fullName: self.homeViewModel.userName?.capitalized))!", displayMode: .inline)
            .navigationBarItems(trailing:
                NavigationLink(destination: ProfileSummary()) {
                        Image(systemName: ImageNameConstants.SFSymbolConstants.profileIcon)
                            .padding([.leading, .vertical])
                            .font(.system(size: DesignConstants.Fonts.Size.navBarIcon))
            })
            .onAppear {
                self.useHomeService()
            }
        }
    }
}

struct Home_Previews: PreviewProvider {
    static var previews: some View {
        Home()
    }
}
