//
//  POPmp4v2dylibloader.m
//  Mp4Autotag
//
//  Created by Kevin Scardina on 12/28/12.
//
//

#import "POPmp4v2dylibloader.h"
#include <dlfcn.h>
@implementation POPmp4v2dylibloader
+(void)loadMp4v2Lib:(NSString*)path
{
	void* mp4v2_lib_handle;
	mp4v2_lib_handle = dlopen("libmp4v2.2.dylib", RTLD_LOCAL|RTLD_LAZY);
	if(!mp4v2_lib_handle)
	{
		mp4v2_lib_handle = dlopen([path cStringUsingEncoding:NSUTF8StringEncoding], RTLD_LOCAL|RTLD_LAZY);
	}
	if(!mp4v2_lib_handle)
	{
		@throw [NSException exceptionWithName:@"FileNotFoundException"
									   reason:[NSString stringWithFormat:@"Unable to load %@", path]
									 userInfo:nil];
	}
	_MP4Modify					 = dlsym(mp4v2_lib_handle, "MP4Modify");
	_MP4TagsAlloc                = dlsym(mp4v2_lib_handle, "MP4TagsAlloc");
	_MP4TagsStore                = dlsym(mp4v2_lib_handle, "MP4TagsStore");
	_MP4TagsFetch                = dlsym(mp4v2_lib_handle, "MP4TagsFetch");
	_MP4TagsFree                 = dlsym(mp4v2_lib_handle, "MP4TagsFree");
	_MP4Close                    = dlsym(mp4v2_lib_handle, "MP4Close");
	_MP4Free                     = dlsym(mp4v2_lib_handle, "MP4Free");
	_MP4TagsSetName              = dlsym(mp4v2_lib_handle, "MP4TagsSetName");
	_MP4TagsSetArtist            = dlsym(mp4v2_lib_handle, "MP4TagsSetArtist");
	_MP4TagsSetAlbumArtist       = dlsym(mp4v2_lib_handle, "MP4TagsSetAlbumArtist");
	_MP4TagsSetAlbum             = dlsym(mp4v2_lib_handle, "MP4TagsSetAlbum");
	_MP4TagsSetGrouping          = dlsym(mp4v2_lib_handle, "MP4TagsSetGrouping");
	_MP4TagsSetComposer          = dlsym(mp4v2_lib_handle, "MP4TagsSetComposer");
	_MP4TagsSetComments          = dlsym(mp4v2_lib_handle, "MP4TagsSetComments");
	_MP4TagsSetGenre             = dlsym(mp4v2_lib_handle, "MP4TagsSetGenre");
	_MP4TagsSetGenreType         = dlsym(mp4v2_lib_handle, "MP4TagsSetGenreType");
	_MP4TagsSetReleaseDate       = dlsym(mp4v2_lib_handle, "MP4TagsSetReleaseDate");
	_MP4TagsSetTrack             = dlsym(mp4v2_lib_handle, "MP4TagsSetTrack");
	_MP4TagsSetDisk              = dlsym(mp4v2_lib_handle, "MP4TagsSetDisk");
	_MP4TagsSetTempo             = dlsym(mp4v2_lib_handle, "MP4TagsSetTempo");
	_MP4TagsSetCompilation       = dlsym(mp4v2_lib_handle, "MP4TagsSetCompilation");
	_MP4TagsSetTVShow            = dlsym(mp4v2_lib_handle, "MP4TagsSetTVShow");
	_MP4TagsSetTVNetwork         = dlsym(mp4v2_lib_handle, "MP4TagsSetTVNetwork");
	_MP4TagsSetTVEpisodeID       = dlsym(mp4v2_lib_handle, "MP4TagsSetTVEpisodeID");
	_MP4TagsSetTVSeason          = dlsym(mp4v2_lib_handle, "MP4TagsSetTVSeason");
	_MP4TagsSetTVEpisode         = dlsym(mp4v2_lib_handle, "MP4TagsSetTVEpisode");
	_MP4TagsSetDescription       = dlsym(mp4v2_lib_handle, "MP4TagsSetDescription");
	_MP4TagsSetLongDescription   = dlsym(mp4v2_lib_handle, "MP4TagsSetLongDescription");
	_MP4TagsSetLyrics            = dlsym(mp4v2_lib_handle, "MP4TagsSetLyrics");
	_MP4TagsSetSortName          = dlsym(mp4v2_lib_handle, "MP4TagsSetSortName");
	_MP4TagsSetSortArtist        = dlsym(mp4v2_lib_handle, "MP4TagsSetSortArtist");
	_MP4TagsSetSortAlbumArtist   = dlsym(mp4v2_lib_handle, "MP4TagsSetSortAlbumArtist");
	_MP4TagsSetSortAlbum         = dlsym(mp4v2_lib_handle, "MP4TagsSetSortAlbum");
	_MP4TagsSetSortComposer      = dlsym(mp4v2_lib_handle, "MP4TagsSetSortComposer");
	_MP4TagsSetSortTVShow        = dlsym(mp4v2_lib_handle, "MP4TagsSetSortTVShow");
	_MP4TagsAddArtwork           = dlsym(mp4v2_lib_handle, "MP4TagsAddArtwork");
	_MP4TagsSetArtwork           = dlsym(mp4v2_lib_handle, "MP4TagsSetArtwork");
	_MP4TagsRemoveArtwork        = dlsym(mp4v2_lib_handle, "MP4TagsRemoveArtwork");
	_MP4TagsSetCopyright         = dlsym(mp4v2_lib_handle, "MP4TagsSetCopyright");
	_MP4TagsSetEncodingTool      = dlsym(mp4v2_lib_handle, "MP4TagsSetEncodingTool");
	_MP4TagsSetEncodedBy         = dlsym(mp4v2_lib_handle, "MP4TagsSetEncodedBy");
	_MP4TagsSetPurchaseDate      = dlsym(mp4v2_lib_handle, "MP4TagsSetPurchaseDate");
	_MP4TagsSetPodcast           = dlsym(mp4v2_lib_handle, "MP4TagsSetPodcast");
	_MP4TagsSetKeywords          = dlsym(mp4v2_lib_handle, "MP4TagsSetKeywords");
	_MP4TagsSetCategory          = dlsym(mp4v2_lib_handle, "MP4TagsSetCategory");
	_MP4TagsSetHDVideo           = dlsym(mp4v2_lib_handle, "MP4TagsSetHDVideo");
	_MP4TagsSetMediaType         = dlsym(mp4v2_lib_handle, "MP4TagsSetMediaType");
	_MP4TagsSetContentRating     = dlsym(mp4v2_lib_handle, "MP4TagsSetContentRating");
	_MP4TagsSetGapless           = dlsym(mp4v2_lib_handle, "MP4TagsSetGapless");
	_MP4TagsSetITunesAccount     = dlsym(mp4v2_lib_handle, "MP4TagsSetITunesAccount");
	_MP4TagsSetITunesAccountType = dlsym(mp4v2_lib_handle, "MP4TagsSetITunesAccountType");
	_MP4TagsSetITunesCountry     = dlsym(mp4v2_lib_handle, "MP4TagsSetITunesCountry");
	/*_MP4TagsSetContentID         = dlsym(mp4v2_lib_handle, "MP4TagsSetSetContentID");
	_MP4TagsSetArtistID          = dlsym(mp4v2_lib_handle, "MP4TagsSetSetArtistID");
	_MP4TagsSetPlaylistID        = dlsym(mp4v2_lib_handle, "MP4TagsSetSetPlaylistID");*/
	_MP4TagsSetGenreID           = dlsym(mp4v2_lib_handle, "MP4TagsSetGenreID");
	_MP4TagsSetComposerID        = dlsym(mp4v2_lib_handle, "MP4TagsSetComposerID");
	_MP4TagsSetXID               = dlsym(mp4v2_lib_handle, "MP4TagsSetXID");
	_MP4MakeIsmaCompliant        = dlsym(mp4v2_lib_handle, "MP4MakeIsmaCompliant");
	_MP4Optimize				 = dlsym(mp4v2_lib_handle, "MP4Optimize");
	_MP4AddChapter				 = dlsym(mp4v2_lib_handle, "MP4AddChapter");
	_MP4SetChapters				 = dlsym(mp4v2_lib_handle, "MP4SetChapters");
	_MP4GetChapters				 = dlsym(mp4v2_lib_handle, "MP4GetChapters");

	if(!_MP4Modify)
	{
		@throw [NSException exceptionWithName:@"FileNotFoundException"
									   reason:@"Unable to load function MP4Modify"
									 userInfo:nil];
	}
	if(!_MP4TagsAlloc)
	{
		@throw [NSException exceptionWithName:@"FileNotFoundException"
									   reason:@"Unable to load function MP4TagsAlloc"
									 userInfo:nil];
	}
	if(!_MP4TagsFetch)
	{
		@throw [NSException exceptionWithName:@"FileNotFoundException"
									   reason:@"Unable to load function MP4TagsFetch"
									 userInfo:nil];
	}
	if(!_MP4TagsStore)
	{
		@throw [NSException exceptionWithName:@"FileNotFoundException"
									   reason:@"Unable to load function MP4TagsStore"
									 userInfo:nil];
	}
	if(!_MP4TagsFree)
	{
		@throw [NSException exceptionWithName:@"FileNotFoundException"
									   reason:@"Unable to load function MP4TagsFree"
									 userInfo:nil];
	}
	if(!_MP4Close)
	{
		@throw [NSException exceptionWithName:@"FileNotFoundException"
									   reason:@"Unable to load function MP4Close"
									 userInfo:nil];
	}
	if(!_MP4Free)
	{
		@throw [NSException exceptionWithName:@"FileNotFoundException"
									   reason:@"Unable to load function MP4Free"
									 userInfo:nil];
	}
	if(!_MP4TagsSetName)
	{
		@throw [NSException exceptionWithName:@"FileNotFoundException"
									   reason:@"Unable to load function MP4TagsSetName"
									 userInfo:nil];
	}
	if(!_MP4TagsSetArtist)
	{
		@throw [NSException exceptionWithName:@"FileNotFoundException"
									   reason:@"Unable to load function MP4TagsSetArtist"
									 userInfo:nil];
	}
	if(!_MP4TagsSetAlbumArtist)
	{
		@throw [NSException exceptionWithName:@"FileNotFoundException"
									   reason:@"Unable to load function MP4TagsSetAlbumArtist"
									 userInfo:nil];
	}
	if(!_MP4TagsSetAlbum)
	{
		@throw [NSException exceptionWithName:@"FileNotFoundException"
									   reason:@"Unable to load function MP4TagsSetAlbum"
									 userInfo:nil];
	}
	if(!_MP4TagsSetGrouping)
	{
		@throw [NSException exceptionWithName:@"FileNotFoundException"
									   reason:@"Unable to load function MP4TagsSetGrouping"
									 userInfo:nil];
	}
	if(!_MP4TagsSetComposer)
	{
		@throw [NSException exceptionWithName:@"FileNotFoundException"
									   reason:@"Unable to load function MP4TagsSetComposer"
									 userInfo:nil];
	}
	if(!_MP4TagsSetComments)
	{
		@throw [NSException exceptionWithName:@"FileNotFoundException"
									   reason:@"Unable to load function MP4TagsSetComments"
									 userInfo:nil];
	}
	if(!_MP4TagsSetGenre)
	{
		@throw [NSException exceptionWithName:@"FileNotFoundException"
									   reason:@"Unable to load function MP4TagsSetGenre"
									 userInfo:nil];
	}
	if(!_MP4TagsSetGenreType)
	{
		@throw [NSException exceptionWithName:@"FileNotFoundException"
									   reason:@"Unable to load function MP4TagsSetGenreType"
									 userInfo:nil];
	}
	if(!_MP4TagsSetReleaseDate)
	{
		@throw [NSException exceptionWithName:@"FileNotFoundException"
									   reason:@"Unable to load function MP4TagsSetReleaseDate"
									 userInfo:nil];
	}
	if(!_MP4TagsSetTrack)
	{
		@throw [NSException exceptionWithName:@"FileNotFoundException"
									   reason:@"Unable to load function MP4TagsSetTrack"
									 userInfo:nil];
	}
	if(!_MP4TagsSetDisk)
	{
		@throw [NSException exceptionWithName:@"FileNotFoundException"
									   reason:@"Unable to load function MP4TagsSetDisk"
									 userInfo:nil];
	}
	if(!_MP4TagsSetTempo)
	{
		@throw [NSException exceptionWithName:@"FileNotFoundException"
									   reason:@"Unable to load function MP4TagsSetTempo"
									 userInfo:nil];
	}
	if(!_MP4TagsSetCompilation)
	{
		@throw [NSException exceptionWithName:@"FileNotFoundException"
									   reason:@"Unable to load function MP4TagsSetCompilation"
									 userInfo:nil];
	}
	if(!_MP4TagsSetTVShow)
	{
		@throw [NSException exceptionWithName:@"FileNotFoundException"
									   reason:@"Unable to load function MP4TagsSetTVShow"
									 userInfo:nil];
	}
	if(!_MP4TagsSetTVNetwork)
	{
		@throw [NSException exceptionWithName:@"FileNotFoundException"
									   reason:@"Unable to load function MP4TagsSetTVNetwork"
									 userInfo:nil];
	}
	if(!_MP4TagsSetTVEpisodeID)
	{
		@throw [NSException exceptionWithName:@"FileNotFoundException"
									   reason:@"Unable to load function MP4TagsSetTVEpisodeID"
									 userInfo:nil];
	}
	if(!_MP4TagsSetTVSeason)
	{
		@throw [NSException exceptionWithName:@"FileNotFoundException"
									   reason:@"Unable to load function MP4TagsSetTVSeason"
									 userInfo:nil];
	}
	if(!_MP4TagsSetTVEpisode)
	{
		@throw [NSException exceptionWithName:@"FileNotFoundException"
									   reason:@"Unable to load function MP4TagsSetTVEpisode"
									 userInfo:nil];
	}
	if(!_MP4TagsSetDescription)
	{
		@throw [NSException exceptionWithName:@"FileNotFoundException"
									   reason:@"Unable to load function MP4TagsSetDescription"
									 userInfo:nil];
	}
	if(!_MP4TagsSetLongDescription)
	{
		@throw [NSException exceptionWithName:@"FileNotFoundException"
									   reason:@"Unable to load function MP4TagsSetLongDescription"
									 userInfo:nil];
	}
	if(!_MP4TagsSetLyrics)
	{
		@throw [NSException exceptionWithName:@"FileNotFoundException"
									   reason:@"Unable to load function MP4TagsSetLyrics"
									 userInfo:nil];
	}
	if(!_MP4TagsSetSortName)
	{
		@throw [NSException exceptionWithName:@"FileNotFoundException"
									   reason:@"Unable to load function MP4TagsSetSortName"
									 userInfo:nil];
	}
	if(!_MP4TagsSetSortArtist)
	{
		@throw [NSException exceptionWithName:@"FileNotFoundException"
									   reason:@"Unable to load function MP4TagsSetSortArtist"
									 userInfo:nil];
	}
	if(!_MP4TagsSetSortAlbumArtist)
	{
		@throw [NSException exceptionWithName:@"FileNotFoundException"
									   reason:@"Unable to load function MP4TagsSetSortAlbumArtist"
									 userInfo:nil];
	}
	if(!_MP4TagsSetSortAlbum)
	{
		@throw [NSException exceptionWithName:@"FileNotFoundException"
									   reason:@"Unable to load function MP4TagsSetSortAlbum"
									 userInfo:nil];
	}
	if(!_MP4TagsSetSortComposer)
	{
		@throw [NSException exceptionWithName:@"FileNotFoundException"
									   reason:@"Unable to load function MP4TagsSetSortComposer"
									 userInfo:nil];
	}
	if(!_MP4TagsSetSortTVShow)
	{
		@throw [NSException exceptionWithName:@"FileNotFoundException"
									   reason:@"Unable to load function MP4TagsSetSortTVShow"
									 userInfo:nil];
	}
	if(!_MP4TagsAddArtwork)
	{
		@throw [NSException exceptionWithName:@"FileNotFoundException"
									   reason:@"Unable to load function MP4TagsAddArtwork"
									 userInfo:nil];
	}
	if(!_MP4TagsSetArtwork)
	{
		@throw [NSException exceptionWithName:@"FileNotFoundException"
									   reason:@"Unable to load function MP4TagsSetArtwork"
									 userInfo:nil];
	}
	if(!_MP4TagsRemoveArtwork)
	{
		@throw [NSException exceptionWithName:@"FileNotFoundException"
									   reason:@"Unable to load function MP4TagsRemoveArtwork"
									 userInfo:nil];
	}
	if(!_MP4TagsSetCopyright)
	{
		@throw [NSException exceptionWithName:@"FileNotFoundException"
									   reason:@"Unable to load function MP4TagsSetCopyright"
									 userInfo:nil];
	}
	if(!_MP4TagsSetEncodingTool)
	{
		@throw [NSException exceptionWithName:@"FileNotFoundException"
									   reason:@"Unable to load function MP4TagsSetEncodingTool"
									 userInfo:nil];
	}
	if(!_MP4TagsSetEncodedBy)
	{
		@throw [NSException exceptionWithName:@"FileNotFoundException"
									   reason:@"Unable to load function MP4TagsSetEncodedBy"
									 userInfo:nil];
	}
	if(!_MP4TagsSetPurchaseDate)
	{
		@throw [NSException exceptionWithName:@"FileNotFoundException"
									   reason:@"Unable to load function MP4TagsSetPurchaseDate"
									 userInfo:nil];
	}
	if(!_MP4TagsSetPodcast)
	{
		@throw [NSException exceptionWithName:@"FileNotFoundException"
									   reason:@"Unable to load function MP4TagsSetPodcast"
									 userInfo:nil];
	}
	if(!_MP4TagsSetKeywords)
	{
		@throw [NSException exceptionWithName:@"FileNotFoundException"
									   reason:@"Unable to load function MP4TagsSetKeywords"
									 userInfo:nil];
	}
	if(!_MP4TagsSetCategory)
	{
		@throw [NSException exceptionWithName:@"FileNotFoundException"
									   reason:@"Unable to load function MP4TagsSetCategory"
									 userInfo:nil];
	}
	if(!_MP4TagsSetHDVideo)
	{
		@throw [NSException exceptionWithName:@"FileNotFoundException"
									   reason:@"Unable to load function MP4TagsSetHDVideo"
									 userInfo:nil];
	}
	if(!_MP4TagsSetMediaType)
	{
		@throw [NSException exceptionWithName:@"FileNotFoundException"
									   reason:@"Unable to load function MP4TagsSetMediaType"
									 userInfo:nil];
	}
	if(!_MP4TagsSetContentRating)
	{
		@throw [NSException exceptionWithName:@"FileNotFoundException"
									   reason:@"Unable to load function MP4TagsSetContentRating"
									 userInfo:nil];
	}
	if(!_MP4TagsSetGapless)
	{
		@throw [NSException exceptionWithName:@"FileNotFoundException"
									   reason:@"Unable to load function MP4TagsSetGapless"
									 userInfo:nil];
	}
	if(!_MP4TagsSetITunesAccount)
	{
		@throw [NSException exceptionWithName:@"FileNotFoundException"
									   reason:@"Unable to load function MP4TagsSetITunesAccount"
									 userInfo:nil];
	}
	if(!_MP4TagsSetITunesAccountType)
	{
		@throw [NSException exceptionWithName:@"FileNotFoundException"
									   reason:@"Unable to load function MP4TagsSetITunesAccountType"
									 userInfo:nil];
	}
	if(!_MP4TagsSetITunesCountry)
	{
		@throw [NSException exceptionWithName:@"FileNotFoundException"
									   reason:@"Unable to load function MP4TagsSetITunesCountry"
									 userInfo:nil];
	}
	/*
	 NOT WORKING FOR SOME REASON?!?!
	if(!_MP4TagsSetContentID)
	{
		@throw [NSException exceptionWithName:@"FileNotFoundException"
									   reason:@"Unable to load function MP4TagsSetContentID"
									 userInfo:nil];
	}
	if(!_MP4TagsSetArtistID)
	{
		@throw [NSException exceptionWithName:@"FileNotFoundException"
									   reason:@"Unable to load function MP4TagsSetArtistID"
									 userInfo:nil];
	}
	if(!_MP4TagsSetPlaylistID)
	{
		@throw [NSException exceptionWithName:@"FileNotFoundException"
									   reason:@"Unable to load function MP4TagsSetPlaylistID"
									 userInfo:nil];
	}
	 
	 */
	if(!_MP4TagsSetGenreID)
	{
		@throw [NSException exceptionWithName:@"FileNotFoundException"
									   reason:@"Unable to load function MP4TagsSetGenreID"
									 userInfo:nil];
	}
	if(!_MP4TagsSetComposerID)
	{
		@throw [NSException exceptionWithName:@"FileNotFoundException"
									   reason:@"Unable to load function MP4TagsSetComposerID"
									 userInfo:nil];
	}
	if(!_MP4TagsSetXID)
	{
		@throw [NSException exceptionWithName:@"FileNotFoundException"
									   reason:@"Unable to load function MP4TagsSetXID"
									 userInfo:nil];
	}
	if(!_MP4MakeIsmaCompliant)
	{
		@throw [NSException exceptionWithName:@"FileNotFoundException"
									   reason:@"Unable to load function MP4MakeIsmaCompliant"
									 userInfo:nil];
	}
	if(!_MP4Optimize)
	{
		@throw [NSException exceptionWithName:@"FileNotFoundException"
									   reason:@"Unable to load function MP4Optimize"
									 userInfo:nil];
	}
	if(!_MP4AddChapter)
	{
		@throw [NSException exceptionWithName:@"FileNotFoundException"
									   reason:@"Unable to load function MP4AddChapter"
									 userInfo:nil];
	}
	if(!_MP4SetChapters)
	{
		@throw [NSException exceptionWithName:@"FileNotFoundException"
									   reason:@"Unable to load function MP4SetChapters"
									 userInfo:nil];
	}
	if(!_MP4GetChapters)
	{
		@throw [NSException exceptionWithName:@"FileNotFoundException"
									   reason:@"Unable to load function MP4SetChapters"
									 userInfo:nil];
	}
}
@end
