#!/bin/sh
#
# DO NOT ALTER OR REMOVE COPYRIGHT NOTICES OR THIS HEADER.
#
# Copyright (c) 2012-2015 Oracle and/or its affiliates. All rights reserved.
#
# The contents of this file are subject to the terms of either the GNU
# General Public License Version 2 only ("GPL") or the Common Development
# and Distribution License("CDDL") (collectively, the "License").  You
# may not use this file except in compliance with the License.  You can
# obtain a copy of the License at
# https://glassfish.dev.java.net/public/CDDL+GPL_1_1.html
# or packager/legal/LICENSE.txt.  See the License for the specific
# language governing permissions and limitations under the License.
#
# When distributing the software, include this License Header Notice in each
# file and include the License file at packager/legal/LICENSE.txt.
#
# GPL Classpath Exception:
# Oracle designates this particular file as subject to the "Classpath"
# exception as provided by Oracle in the GPL Version 2 section of the License
# file that accompanied this code.
#
# Modifications:
# If applicable, add the following below the License Header, with the fields
# enclosed by brackets [] replaced by your own identifying information:
# "Portions Copyright [year] [name of copyright owner]"
#
# Contributor(s):
# If you wish your version of this file to be governed by only the CDDL or
# only the GPL Version 2, indicate your decision by adding "[Contributor]
# elects to include this software in this distribution under the [CDDL or GPL
# Version 2] license."  If you don't indicate a single choice of license, a
# recipient has the option to distribute your version of this file under
# either the CDDL, the GPL Version 2 or to extend the choice of license to
# its licensees as provided above.  However, if you add GPL Version 2 code
# and therefore, elected the GPL Version 2 license, then the option applies
# only if the new code is made subject to such option by the copyright
# holder.
#

#
#------------------------------------------------------   
#--	BE SURE TO HAVE THE FOLLOWING IN YOUR SETTINGS.XML
#------------------------------------------------------
#
#    <servers>
#        <server>
#            <id>jvnet-nexus-staging</id>
#            <username>jvnet_id</username>
#            <password>password</password>
#        </server>
#    </servers>

# see the following URL for gpg issues
# https://docs.sonatype.org/display/Repository/How+To+Generate+PGP+Signatures+With+Maven#HowToGeneratePGPSignaturesWithMaven-GenerateaKeyPair

# on solaris, lets assume gsed is in the PATH
if [ `uname | grep -i sunos | wc -l` -eq 1 ]
then
    SED="gsed"
else
    SED="sed"
fi

# on OSX, -r is -E
if [ `uname | grep -i darwin | wc -l` -eq 1 ]
then
	SED_OPTS="-Ee"
else
	SED_OPTS="-re"
fi

CURRENT_VERSION=`grep "<version>" pom.xml | head -2 | tail -1 | $SED $SED_OPTS 's/.*<version>(.*)<\/version>/\1/'`
echo $CURRENT_VERSION
NEXT_RELEASE_VERSION=`echo $CURRENT_VERSION | sed s@"-SNAPSHOT"@@g`
NEXT_RELEASE_TAG="javax.jms-api-$NEXT_RELEASE_VERSION"

# remove local changes
svn revert -R .

# remove unversioned files
svn status | grep ? | awk '{print $2}' | xargs rm -rf

# remove tag if exist
svn del svn+ssh://$USER@svn.java.net/glassfish~svn/tags/$NEXT_RELEASE_TAG -m "delete tag" || true

ARGS=" $*"
# everything supplied as argument will be provided to every maven command.
# e.g to supply -Dmaven.skip.test or -Dmaven.repo.local=/path/to/repo

mvn -B -e release:prepare -DpreparationGoals="'install' $ARGS" $ARGS -Prelease
mvn -B -e release:perform -Dgoals="'deploy' $ARGS" $ARGS -Prelease
