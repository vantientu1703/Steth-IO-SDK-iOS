//
//  GLStethShaders.h
//  Steth.io
//
//  Created by Tom Andersen on 2015/1/21.
//  Copyright (c) 2015 Strato Scientific. All rights reserved.
//

#ifndef __Steth_io__GLStethShaders__
#define __Steth_io__GLStethShaders__

#include <stdlib.h>
#include <stdio.h>
#include <string.h>
#include <math.h>
#include <OpenGLES/ES2/gl.h>


void glsteth_usePowerShaderProgram(GLint* outPositionSlot, GLint* outColorSlot, GLint* outOrthoProjectionSlot);
void glsteth_useOrtho01ProjectionMatrix(GLint slotLocation);

void glsteth_useConstantColourProgram(GLint* outPositionSlot, GLint* outColorSlot, GLint* outOrthoProjectionSlot);


#endif /* defined(__Steth_io__GLStethShaders__) */
