// CKGoogleMapsViewController.m
//
// Copyright © 2017 Hulab. All rights reserved.
//
// Permission is hereby granted, free of charge, to any person obtaining a copy
// of this software and associated documentation files (the "Software"), to deal
// in the Software without restriction, including without limitation the rights
// to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
// copies of the Software, and to permit persons to whom the Software is
// furnished to do so, subject to the following conditions:
//
// The above copyright notice and this permission notice shall be included in
// all copies or substantial portions of the Software.
//
// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
// IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
// FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
// AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
// LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
// OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
// THE SOFTWARE.

#import <ParisOpenData/ParisOpenData.h>
#import <ParisOpenDataUI/ParisOpenDataUI.h>

#import <GoogleMaps/GoogleMaps.h>
#import <ClusterKit/ClusterKit.h>

#import "GMSMapView+ClusterKit.h"

#import "CKGoogleMapsViewController.h"
#import "CKTreeClusterView.h"

@interface CKGoogleMapsViewController () <GMSMapViewDelegate,GMSMapViewDataSource>
@property (weak, nonatomic) IBOutlet GMSMapView *mapView;
@end

@implementation CKGoogleMapsViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.mapView.delegate = self;
    self.mapView.settings.compassButton = YES;

    CKNonHierarchicalDistanceBasedAlgorithm *algorithm = [CKNonHierarchicalDistanceBasedAlgorithm new];
    algorithm.cellSize = 200;
    
    self.mapView.clusterManager.algorithm = algorithm;
    self.mapView.clusterManager.marginFactor = 1;
    self.mapView.dataSource = self;
    
    [self loadMuseums];
}

- (void)didLoadPoints:(NSArray<CKPointObject *> *)points {
    self.mapView.clusterManager.annotations = points;
}

#pragma mark <GMSMapViewDelegate>

- (void)mapView:(GMSMapView *)mapView idleAtCameraPosition:(GMSCameraPosition *)position {
    [mapView.clusterManager updateClustersIfNeeded];
}

- (BOOL)mapView:(GMSMapView *)mapView didTapMarker:(GMSMarker *)marker {
    if (marker.cluster.count > 1) {
        UIEdgeInsets padding = UIEdgeInsetsMake(40, 20, 44, 20);
        GMSCameraUpdate *cameraUpdate = [GMSCameraUpdate fitCluster:marker.cluster withEdgeInsets:padding];
        [mapView animateWithCameraUpdate:cameraUpdate];
        return YES;
    }
    return NO;
}

#pragma mark <GMSMapViewDataSource>

- (GMSMarker *)mapView:(GMSMapView *)mapView markerForCluster:(CKCluster *)cluster {
    GMSMarker *marker = [GMSMarker markerWithPosition:cluster.coordinate];
    if(cluster.count > 1) {
        marker.icon = [UIImage imageNamed:@"cluster"];
    } else {
        marker.icon = [UIImage imageNamed:@"marker"];
        marker.title = cluster.title;
    }
    
    return marker;
}

@end
