//
// Copyright Amazon.com Inc. or its affiliates.
// All Rights Reserved.
//
// SPDX-License-Identifier: Apache-2.0
//

extension EventStream {

    /// Stream adapter that decodes input data into `EventStream.Message` objects.
    public struct DefaultMessageDecoderStream<Event: MessageUnmarshallable>: MessageDecoderStream {
        public typealias Element = Event

        let stream: Stream
        let messageDecoder: MessageDecoder
        let responseDecoder: ResponseDecoder

        public init(stream: Stream, messageDecoder: MessageDecoder, responseDecoder: ResponseDecoder) {
            self.stream = stream
            self.messageDecoder = messageDecoder
            self.responseDecoder = responseDecoder
        }

        public struct AsyncIterator: AsyncIteratorProtocol {
            let stream: Stream
            let messageDecoder: MessageDecoder
            let responseDecoder: ResponseDecoder

            init(stream: Stream, messageDecoder: MessageDecoder, responseDecoder: ResponseDecoder) {
                self.stream = stream
                self.messageDecoder = messageDecoder
                self.responseDecoder = responseDecoder
            }

            mutating public func next() async throws -> Event? {
                // if we have a message in the decoder buffer, return it
                if let message = try messageDecoder.message() {
                    let event = try Event(message: message, decoder: responseDecoder)
                    return event
                }

                // read until the end of the stream
                while let data = try await stream.readAsync(upToCount: Int.max) {
                    // feed the data to the decoder
                    // this may result in a message being returned
                    try messageDecoder.feed(data: data)

                    // if we have a message in the decoder buffer, return it
                    if let message = try messageDecoder.message() {
                        let event = try Element(message: message, decoder: responseDecoder)
                        return event
                    }
                }

                // this is the end of the stream
                // notify the decoder that the stream has ended
                try messageDecoder.endOfStream()
                return nil
            }
        }

        public func makeAsyncIterator() -> AsyncIterator {
            AsyncIterator(
                stream: stream,
                messageDecoder: messageDecoder,
                responseDecoder: responseDecoder
            )
        }
    }
}
