//
//  POPmp4v2dylibloader.h
//  Mp4Autotag
//
//  Created by Kevin Scardina on 12/28/12.
//
//

#import <Foundation/Foundation.h>
#include <mp4v2/mp4v2.h>

void* (*_MP4Modify               ) ( const char*, uint32_t );
const MP4Tags* (*_MP4TagsAlloc   ) ( void );
bool (*_MP4TagsFetch             ) ( const MP4Tags*, MP4FileHandle );
bool (*_MP4TagsStore             ) ( const MP4Tags*, MP4FileHandle );
void (*_MP4TagsFree              ) ( const MP4Tags* );
void (*_MP4Close                 ) ( MP4FileHandle, uint32_t );
void (*_MP4Free                  ) (void*);
bool (*_MP4TagsSetName           ) ( const MP4Tags*, const char* );
bool (*_MP4TagsSetArtist         ) ( const MP4Tags*, const char* );
bool (*_MP4TagsSetAlbumArtist    ) ( const MP4Tags*, const char* );
bool (*_MP4TagsSetAlbum          ) ( const MP4Tags*, const char* );
bool (*_MP4TagsSetGrouping       ) ( const MP4Tags*, const char* );
bool (*_MP4TagsSetComposer       ) ( const MP4Tags*, const char* );
bool (*_MP4TagsSetComments       ) ( const MP4Tags*, const char* );
bool (*_MP4TagsSetGenre          ) ( const MP4Tags*, const char* );
bool (*_MP4TagsSetGenreType      ) ( const MP4Tags*, const uint16_t* );
bool (*_MP4TagsSetReleaseDate    ) ( const MP4Tags*, const char* );
bool (*_MP4TagsSetTrack          ) ( const MP4Tags*, const MP4TagTrack* );
bool (*_MP4TagsSetDisk           ) ( const MP4Tags*, const MP4TagDisk* );
bool (*_MP4TagsSetTempo          ) ( const MP4Tags*, const uint16_t* );
bool (*_MP4TagsSetCompilation    ) ( const MP4Tags*, const uint8_t* );
bool (*_MP4TagsSetTVShow         ) ( const MP4Tags*, const char* );
bool (*_MP4TagsSetTVNetwork      ) ( const MP4Tags*, const char* );
bool (*_MP4TagsSetTVEpisodeID    ) ( const MP4Tags*, const char* );
bool (*_MP4TagsSetTVSeason       ) ( const MP4Tags*, const uint32_t* );
bool (*_MP4TagsSetTVEpisode      ) ( const MP4Tags*, const uint32_t* );
bool (*_MP4TagsSetDescription    ) ( const MP4Tags*, const char* );
bool (*_MP4TagsSetLongDescription) ( const MP4Tags*, const char* );
bool (*_MP4TagsSetLyrics         ) ( const MP4Tags*, const char* );
bool (*_MP4TagsSetSortName       ) ( const MP4Tags*, const char* );
bool (*_MP4TagsSetSortArtist     ) ( const MP4Tags*, const char* );
bool (*_MP4TagsSetSortAlbumArtist) ( const MP4Tags*, const char* );
bool (*_MP4TagsSetSortAlbum      ) ( const MP4Tags*, const char* );
bool (*_MP4TagsSetSortComposer   ) ( const MP4Tags*, const char* );
bool (*_MP4TagsSetSortTVShow     ) ( const MP4Tags*, const char* );
bool (*_MP4TagsAddArtwork        ) ( const MP4Tags*, MP4TagArtwork* );
bool (*_MP4TagsSetArtwork        ) ( const MP4Tags*, uint32_t, MP4TagArtwork* );
bool (*_MP4TagsRemoveArtwork     ) ( const MP4Tags*, uint32_t );
bool (*_MP4TagsSetCopyright      ) ( const MP4Tags*, const char* );
bool (*_MP4TagsSetEncodingTool   ) ( const MP4Tags*, const char* );
bool (*_MP4TagsSetEncodedBy      ) ( const MP4Tags*, const char* );
bool (*_MP4TagsSetPurchaseDate   ) ( const MP4Tags*, const char* );
bool (*_MP4TagsSetPodcast        ) ( const MP4Tags*, const uint8_t* );
bool (*_MP4TagsSetKeywords       ) ( const MP4Tags*, const char* );
bool (*_MP4TagsSetCategory       ) ( const MP4Tags*, const char* );
bool (*_MP4TagsSetHDVideo        ) ( const MP4Tags*, const uint8_t* );
bool (*_MP4TagsSetMediaType      ) ( const MP4Tags*, const uint8_t* );
bool (*_MP4TagsSetContentRating  ) ( const MP4Tags*, const uint8_t* );
bool (*_MP4TagsSetGapless        ) ( const MP4Tags*, const uint8_t* );
bool (*_MP4TagsSetITunesAccount    ) ( const MP4Tags*, const char* );
bool (*_MP4TagsSetITunesAccountType) ( const MP4Tags*, const uint8_t* );
bool (*_MP4TagsSetITunesCountry    ) ( const MP4Tags*, const uint32_t* );
/*bool (*_MP4TagsSetContentID        ) ( const MP4Tags*, const uint32_t* );
bool (*_MP4TagsSetArtistID         ) ( const MP4Tags*, const uint32_t* );
bool (*_MP4TagsSetPlaylistID       ) ( const MP4Tags*, const uint64_t* );*/
bool (*_MP4TagsSetGenreID          ) ( const MP4Tags*, const uint32_t* );
bool (*_MP4TagsSetComposerID       ) ( const MP4Tags*, const uint32_t* );
bool (*_MP4TagsSetXID              ) ( const MP4Tags*, const char* );
bool (*_MP4MakeIsmaCompliant       ) ( const char*, bool );
bool (*_MP4Optimize				   ) ( const char*, const char* );
MP4ChapterType (*_MP4AddChapter	   ) (MP4FileHandle, MP4TrackId, MP4Duration, const char*);
MP4ChapterType (*_MP4SetChapters   ) (MP4FileHandle, MP4Chapter_t*, uint32_t, MP4ChapterType);
MP4ChapterType (*_MP4GetChapters   ) (MP4FileHandle, MP4Chapter_t **, uint32_t *, MP4ChapterType);

@interface POPmp4v2dylibloader : NSObject
+(void)loadMp4v2Lib:(NSString*)path;
@end
