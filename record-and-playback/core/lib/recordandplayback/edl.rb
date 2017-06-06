# encoding: UTF-8

# BigBlueButton open source conferencing system - http://www.bigbluebutton.org/
#
# Copyright (c) 2013 BigBlueButton Inc. and by respective authors.
#
# BigBlueButton is free software: you can redistribute it and/or modify it
# under the terms of the GNU Lesser General Public License as published by the
# Free Software Foundation, either version 3 of the License, or (at your
# option) any later version.
#
# BigBlueButton is distributed in the hope that it will be useful, but WITHOUT
# ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS
# FOR A PARTICULAR PURPOSE.  See the GNU Lesser General Public License for more
# details.
#
# You should have received a copy of the GNU Lesser General Public License
# along with BigBlueButton.  If not, see <http://www.gnu.org/licenses/>. 

require File.expand_path('../edl/video', __FILE__)
require File.expand_path('../edl/audio', __FILE__)

module BigBlueButton
  module EDL
    FFMPEG = ['ffmpeg', '-y', '-v', 'warning', '-nostats']
    FFPROBE = ['ffprobe', '-v', 'warning', '-print_format', 'json', '-show_format', '-show_streams', '-count_frames']

    def self.encode(audio, video, format, output_basename, audio_offset = 0)
      output = "#{output_basename}.#{format[:extension]}"
      lastoutput = nil
      format[:parameters].each_with_index do |pass, i|
        BigBlueButton.logger.info "Performing video encode pass #{i}"
        lastoutput = "#{output_basename}.encode.#{format[:extension]}"
        ffmpeg_cmd = FFMPEG
        ffmpeg_cmd += ['-i', video] if video
        if audio
          if audio_offset != 0
            ffmpeg_cmd += ['-itsoffset', ms_to_s(audio_offset)]
          end
          # Ensure that the entire contents of freeswitch wav files are read
          if BigBlueButton::EDL::Audio.audio_info(audio)[:format][:format_name] == 'wav'
            ffmpeg_cmd += ['-ignore_length', '1']
          end
          ffmpeg_cmd += ['-i', audio]
        end
        ffmpeg_cmd += [*pass, lastoutput]
        Dir.chdir(File.dirname(output)) do
          exitstatus = BigBlueButton.exec_ret(*ffmpeg_cmd)
          raise "ffmpeg failed, exit code #{exitstatus}" if exitstatus != 0
        end
      end

      # Some formats have post-processing to prepare for streaming
      if format[:postprocess]
        format[:postprocess].each_with_index do |pp, i|
          BigBlueButton.logger.info "Performing post-processing step #{i}"
          ppoutput = "#{output_basename}.pp#{i}.#{format[:extension]}"
          cmd = pp.map do |arg|
            case arg
            when ':input'
              lastoutput
            when ':output'
              ppoutput
            else
              arg
            end
          end
          Dir.chdir(File.dirname(output)) do
            exitstatus = BigBlueButton.exec_ret(*cmd)
            raise "postprocess failed, exit code #{exitstatus}" if exitstatus != 0
          end
          lastoutput = ppoutput
        end
      end

      FileUtils.mv(lastoutput, output)

      return output
    end

    #Compose the two videos horizontally
    #First, we expand the width (using new_width),
    #then we put the deskshare video at x = 0 and the webcam video at x = x_divider
    #IMPORTANT: we assume that the webcam video has smaller height than the deskshare video
    def self.compose_videos(audio, webcam_video, deskshare_video, new_width, x_divider, format, output_basename, audio_offset = 0)
      if (webcam_video == nil || deskshare_video == nil)
        BigBlueButton.logger.info "compose_videos: invalid video"
        return
      end
      output = "#{output_basename}.#{format[:extension]}"
      lastoutput = nil
      format[:parameters].each_with_index do |pass, i|
        BigBlueButton.logger.info "Performing video composition pass #{i}"
        lastoutput = "#{output_basename}.encode.#{format[:extension]}"
        ffmpeg_cmd = FFMPEG
        ffmpeg_cmd += ['-i', deskshare_video]
        ffmpeg_cmd += ['-i', webcam_video]
        if audio
          if audio_offset != 0
            ffmpeg_cmd += ['-itsoffset', ms_to_s(audio_offset)]
          end
          # Ensure that the entire contents of freeswitch wav files are read
          if BigBlueButton::EDL::Audio.audio_info(audio)[:format][:format_name] == 'wav'
            ffmpeg_cmd += ['-ignore_length', '1']
          end
          ffmpeg_cmd += ['-i', audio]
        end
        filter = "[0:v]pad=#{new_width}:ih[int];[int][1:v]overlay=#{x_divider}:0[vid]"
        ffmpeg_cmd += ['-filter_complex', filter]
        ffmpeg_cmd += ['-map', '[vid]']
        ffmpeg_cmd += ['-map', '2:a'] if audio
        ffmpeg_cmd += [*pass, lastoutput]
        Dir.chdir(File.dirname(output)) do
          exitstatus = BigBlueButton.exec_ret(*ffmpeg_cmd)
          raise "ffmpeg failed, exit code #{exitstatus}" if exitstatus != 0
        end
      end

      # Some formats have post-processing to prepare for streaming
      if format[:postprocess]
        format[:postprocess].each_with_index do |pp, i|
          BigBlueButton.logger.info "Performing post-processing step #{i}"
          ppoutput = "#{output_basename}.pp#{i}.#{format[:extension]}"
          cmd = pp.map do |arg|
            case arg
            when ':input'
              lastoutput
            when ':output'
              ppoutput
            else
              arg
            end
          end
          Dir.chdir(File.dirname(output)) do
            exitstatus = BigBlueButton.exec_ret(*cmd)
            raise "postprocess failed, exit code #{exitstatus}" if exitstatus != 0
          end
          lastoutput = ppoutput
        end
      end

      FileUtils.mv(lastoutput, output)

      return output
    end

    def self.ms_to_s(timestamp)
      s = timestamp / 1000
      ms = timestamp % 1000
      "%d.%03d" % [s, ms]
    end    

  end
end
